Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04480C32754
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:48:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1135216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:48:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mjC+j0aa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1135216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4ACA48E0013; Thu,  1 Aug 2019 08:48:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 436998E0001; Thu,  1 Aug 2019 08:48:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B0888E0013; Thu,  1 Aug 2019 08:48:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E1B8F8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 08:48:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25so45655085pfn.5
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 05:48:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ATAFhJly7oayn4QwVxAmF/cKx18eZXYIEq5cLXvpdzg=;
        b=JLblBVb6cg4EOQfIgkPqc9Zqlk+uAoxTw3rkN9sTIJfYOJKpPjOnTlnX6Ni71Yvz1A
         gK0QnmvnxSWWMzIKKEbO7EbLObRxiv3ErIVtBHPkSLiIOxI4G+v/RzEepW+0CgtsH7Nd
         QMQAhL53zw8BGujPm5bMrtzQrgxdgkgeXpWe9acavkv48pKP+TQ5VFV3YUxtosAUq02X
         Jz4inrw4aFFKRG9LPy+lEYkLV9NN5YlNw4j878gM5YfwnDHqh07YAuTkYAvuCVqKjKHw
         tN7JPPz3YpYVB4ZHI7w8n0h+4YCPTasbMLrIBq3uH5iYfR2Tzj9lmxkvpR7FmMi5Ff/A
         yVfQ==
X-Gm-Message-State: APjAAAWXu1mJLRBhM5240oDWa9bH+qLT0izgZkNi/KKX9y7Kc66KD2PZ
	AOls5Rt93eRZu1ToK6gw4hFiYJshzEBtKUyCq9yBLSjl/S46sfYaKdRiiQpVPtQum+VGaw/+DcS
	JPVznEhWfLC0F7fkTRPO1WeQJCFZmzcEiY0bUqyvFKz2at0BT5FNfa9oY1+OUbTn8cw==
X-Received: by 2002:a65:430b:: with SMTP id j11mr117155054pgq.383.1564663730383;
        Thu, 01 Aug 2019 05:48:50 -0700 (PDT)
X-Received: by 2002:a65:430b:: with SMTP id j11mr117155017pgq.383.1564663729680;
        Thu, 01 Aug 2019 05:48:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564663729; cv=none;
        d=google.com; s=arc-20160816;
        b=KQEDLfqbWlnGIzOTlh2fBSsNXijyiwzh3amzv8kN+QrOaRf3iClD04nC+ONmFns+Od
         Ys4Onf/DScKDSdu2zKWAXJDNeLArju23uIiprUE711X76jeyidy5sOA6B5FZmEzx3dFD
         Ro/HCLsQPyLSYV2YkeHbE98EsD2/V1r5EKs90P/qtOi0/NwiEGTJftI5iNiLKe9op0oL
         wUKGOQqvAXKRDnvEzRLVSVXH5kwu3c8xgngsCVV/nGpWVl/h5Kt3FNwb5czhbcs3gGBB
         /YHZmrknBW06MHP4XsV3rnUSGk27sZwAb5APtrqx0aRnYQrlHYv2o+SdIyFEFTO/0UDy
         BGfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ATAFhJly7oayn4QwVxAmF/cKx18eZXYIEq5cLXvpdzg=;
        b=JahKfZzM7m/d1JH1tPCL457lqaZTR5ECMGmrHkk1IFvgK79pnVkaStpBYaR6quHo4T
         +RKb1baO+ecC1KK0zcUDZ0pQwEqX/AUdjANxMTA7/4+P9WWZXTYdgocueoOHB+Kh38S5
         Es9istIbYExyRH8Jm527OwO5Zrmm0jRqA7Vpe5OWh8ALiwuulik/SLzn7lYRTgWZX/el
         RblCxTY84aEhqW/LpGzqhuu+TzYMaeRjo5ULFqJa2BuTLJq+kCNS+Z4iZtokzKMYMlj7
         Yyllhxjtv3aYCDACVAxwb5pc7sDWg1mblco4ExXTYzQk4P3QvSvYLOlNB8UnoXtFhU/d
         //mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mjC+j0aa;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6sor48609179pgs.79.2019.08.01.05.48.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 05:48:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mjC+j0aa;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ATAFhJly7oayn4QwVxAmF/cKx18eZXYIEq5cLXvpdzg=;
        b=mjC+j0aaEEkkMHnLNHs9TEJqIdScFWRlkAZG8TbiBl3AyUZ8l5nLaU29ZLHSb7WvwH
         X3OlQDdgsBZjncfM3ONy8Dqcuih1q2WnbLztoEOKMtf5vefqmMIHHwchJuo+ue+DCVka
         b9rui+0AvY5PeeX+qJY2jvBZQab/NzRkSsMupCgkTdlEDxE6K7Nu5zDKiMeGfnD3hicf
         2VPYUTHD9bJKAQWesHnbiPWY9rwW/eF7WIHmcnvL9DkrJEokfA1mnjx39I+4RQdt1WLM
         ieuyPRr8iw6XMHiEGmpinxm+wGAydMTsA6N4zI0Tg/WWtENcJ84NKdjINucR3C9EQWXN
         EQGw==
X-Google-Smtp-Source: APXvYqyuYmWo+CP2FzNWYkHFT0ZLT3W5Y5OJQeMQdVh76HiNmdD4jPQ2fznL3kD7gDek9Cqsx8/zBcK9HOnHQgVpStE=
X-Received: by 2002:a65:4b8b:: with SMTP id t11mr118476394pgq.130.1564663728917;
 Thu, 01 Aug 2019 05:48:48 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com> <8c618cc9-ae68-9769-c5bb-67f1295abc4e@intel.com>
 <13b4cf53-3ecb-f7e7-b504-d77af15d77aa@arm.com>
In-Reply-To: <13b4cf53-3ecb-f7e7-b504-d77af15d77aa@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 1 Aug 2019 14:48:37 +0200
Message-ID: <CAAeHK+zTFqsLiB3Wf0bAi5A8ukQX5ZuvfUg4td-=r5UhBsUBOQ@mail.gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
To: Kevin Brodsky <kevin.brodsky@arm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 1, 2019 at 2:11 PM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
>
> On 31/07/2019 17:50, Dave Hansen wrote:
> > On 7/23/19 10:58 AM, Andrey Konovalov wrote:
> >> The mmap and mremap (only new_addr) syscalls do not currently accept
> >> tagged addresses. Architectures may interpret the tag as a background
> >> colour for the corresponding vma.
> > What the heck is a "background colour"? :)
>
> Good point, this is some jargon that we started using for MTE, the idea being that
> the kernel could set a tag value (specified during mmap()) as "background colour" for
> anonymous pages allocated in that range.
>
> Anyway, this patch series is not about MTE. Andrey, for v20 (if any), I think it's
> best to drop this last sentence to avoid any confusion.

Sure, thanks!

>
> Kevin

