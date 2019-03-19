Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B14E6C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:54:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72CDB20863
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:54:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="TJ1Okd/P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72CDB20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 139AB6B0005; Tue, 19 Mar 2019 15:54:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C1F66B0006; Tue, 19 Mar 2019 15:54:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECC2B6B0007; Tue, 19 Mar 2019 15:54:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8B126B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:54:53 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j10so5235pfn.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:54:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+USuLGAVfj14nrnBqSIcBSk7vFbU2E8ZesZxqqH4cEY=;
        b=Fh3ARIF6L0v0WYo8QsfJKhGtFBedSFIZyxc+zEjMUjKrFS2N662Io5R0u1PFi9iTEK
         JhQ1sGE4lGXocFCGQljyH6q6Nu0XOR0uLI2omvfJEhb4LU+m5GnVCwE701Jg8Y9YNRkv
         YgxXVBcRHwk7fA6+ez1UxZ1UE70ojUfzZEtnXe8x3SlTvPyuE+7+kOpYuUSeDyBtxvCS
         zOt1msOkb7QPT3c8Xjn63lfkelf0btQHjH0kCX6P4NetTfkrDIEodLSsIWSDw4I7AfW/
         Uh9dY3cYivommLJd8XpQe7XAvYK7z/7qz5yfetqMbEswS60Db6y29jtRC+t79hJAUSHa
         lZKw==
X-Gm-Message-State: APjAAAUqE+OOe/FN0MBOjLOGaPFk7e9h8f60xuqCIAaGUaqcU7HMmK34
	Q9/mwKN9Fepbw4YuiA8CvofyzzJqyO726Bv6q+gjWe6OcU+ooYpT1S51R5IrChdGujBUclcmCsY
	ZskIFv1Vsd4/OuvlYIp4sYWbWFjiXsYJR1CDpoJFqP6CLlUjkrzu3IKETi1jMavmo+w==
X-Received: by 2002:a65:4806:: with SMTP id h6mr3476291pgs.408.1553025293351;
        Tue, 19 Mar 2019 12:54:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy34ospDrpdrwhZpIYDDry74enZMjGDYyrgwqrfy2N81dW+ZyZ+6J10evnueqDD6A6GyMpl
X-Received: by 2002:a65:4806:: with SMTP id h6mr3476224pgs.408.1553025292253;
        Tue, 19 Mar 2019 12:54:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553025292; cv=none;
        d=google.com; s=arc-20160816;
        b=uK2SROdUOt/r7fX7+Eav+bjN7bKlZXn+Rv05+B7yRZ7b2m+DbTjzGOtMtTamG7MOWC
         M+UYgaKeTksA9okEnh9PHMbVh/J3ibm5tpH9mBrEEpnEX0QIPXX3mvDbyrUvX6i6KeW2
         hL8yTqSe4jwrAX5p9+lx2ZPYzBftEEBuegrmu6hleKVPwthOwpLwhcTJZJX7sWxcmoAo
         dyVdnSrtqQVSWDiJFkiUualNxuNpXUmqAMR8ow48MbknetX4uy7nvRCO9CY3d5uLsf/j
         u65PQPEjrtbT+ObP8IkuFPzp0iztZUqZQA13NPSj/8nsZNcmky1FpxP+R+t/hU/rlzG9
         WdpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+USuLGAVfj14nrnBqSIcBSk7vFbU2E8ZesZxqqH4cEY=;
        b=X0FxeIGduS6iPOSdXpFzzWi9/fTwiDkbi8dgfCBrMVmvGe5pxOrfnl6C7RCvD9vj8V
         CMCZNRJMLG5KZ2Ti95qvoP0K6XbMq66pifnSyLjJpHBGPqB6dyu2BaxfB7+7uJo+zMM8
         xJFKl7WTs99EvQAXU1eSi519SoNlKxmd1EZ1lE1njl9a28MkOMdKBSxtvm9PVfi4iQq/
         BFezjMX4XlB1Fsqs5RmBg+r8Qyv0xz7q50mGj7soNy0kXRclnbzrcsfwDPah8BdmehhU
         tp9xHfbDIRrT7PqIH3v1LiNyVVAVeThLxgpF6YtUabt8YZ9Chh4kLPR2CPtqAKrK55cf
         aI9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="TJ1Okd/P";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p19si12838450plq.29.2019.03.19.12.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 12:54:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="TJ1Okd/P";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4B2FB2075C;
	Tue, 19 Mar 2019 19:54:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553025291;
	bh=+USuLGAVfj14nrnBqSIcBSk7vFbU2E8ZesZxqqH4cEY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=TJ1Okd/PYOkUgkbR/iUGyt4k369MptFf1PmSSdUE7mxvMof0KCwjc1wuYqhv0w4oF
	 9bZRkzSUnARPXhNosSWp0M/f2TZW2lIF/k6qVWD+0KJr2BGYKp59nlyuu6LMze0Lb/
	 hxK35lScQlBDmpZmFzqkato2hAAXgHaO0NaIkIF0=
Date: Tue, 19 Mar 2019 15:54:48 -0400
From: Sasha Levin <sashal@kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 22/33] kasan, slab: make freelist stored
 without tags
Message-ID: <20190319195448.GA25262@sasha-vm>
References: <20190313191506.159677-1-sashal@kernel.org>
 <20190313191506.159677-22-sashal@kernel.org>
 <CAAeHK+xMxX3Baou=W914tbbPhuPGCBd4wJdgS3O459JEwxw5OQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAAeHK+xMxX3Baou=W914tbbPhuPGCBd4wJdgS3O459JEwxw5OQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 08:18:24PM +0100, Andrey Konovalov wrote:
>On Wed, Mar 13, 2019 at 8:16 PM Sasha Levin <sashal@kernel.org> wrote:
>>
>> From: Andrey Konovalov <andreyknvl@google.com>
>>
>> [ Upstream commit 51dedad06b5f6c3eea7ec1069631b1ef7796912a ]
>
>Hi Sasha,
>
>None of the 4.9, 4.14, 4.19 or 4.20 have tag-based KASAN, so
>backporting these 3 KASAN related patches doesn't make much sense.
>
>Thanks!

Dropped, thank you!

--
Thanks,
Sasha

