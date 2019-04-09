Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ADEAC10F13
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 02:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18AEB217F4
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 02:44:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18AEB217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CEEC6B0008; Mon,  8 Apr 2019 22:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77CB76B000C; Mon,  8 Apr 2019 22:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66B596B0010; Mon,  8 Apr 2019 22:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 458DA6B0008
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 22:44:30 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g48so14632096qtk.19
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 19:44:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=GWVLGd3rRWNvU7sP85NRp5wt10btcwDSd57p3ueaPIg=;
        b=Gk/yeBzNJ3vl4QUPxk18QYbpKUP09Cg3cLgtAg6bmIsC3gjR+ZT5brQHz2xMP6HOFg
         V4ml8mNsr3IldDJQ3CcrUpL4s/MiTA6TOdCyANCQsd0mtguhpBn92kFki4cqLHXv13iW
         fJiNP+yYjBGpNWpNR8J7Ef6I1eTbjX5xSMqyTY5ATZMa6Hehm3Bo1m+sot42Q4Y6PfmP
         reJuN5UBtatj4h3hrR1rtPiX87lMXk/eB/bKMAbYijnwXeiQ7EnxhOsbfbSNsjXfK8V9
         i3yIjhA0flMJcaYJF91Un8dNXxm8al5dW7et8nGSuQH6M8JcBYSNcac1KolI5YOTOVFw
         7RoQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVgDhrJ4LxsLL8mI8wDJGmez8plGg1/x8lYsviikF/rDOQL2dep
	iffx+uUmcktinyICr3pYOEi3c4S8s2MZjBw4hKxg8qtiNJEaOESF9R6imwQ/pjTqm8kSmIojtRp
	UdDUykVet9yRpc8bFFYUlFxzK4dkDdKwpx2E7ZnbDIA1CcZKxnYrsAK6DBdiqN8Dh8A==
X-Received: by 2002:a37:a557:: with SMTP id o84mr26471805qke.277.1554777869947;
        Mon, 08 Apr 2019 19:44:29 -0700 (PDT)
X-Received: by 2002:a37:a557:: with SMTP id o84mr26471775qke.277.1554777869259;
        Mon, 08 Apr 2019 19:44:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554777869; cv=none;
        d=google.com; s=arc-20160816;
        b=YB7+IS2uPPfX+nHc5g+Abz3NNGUefvtNWTEBecir7Ds+rvsbmvJiSUN1S99bCW5H7q
         YUnj7hus+L8dBAF4iTNGXjExdl8knxoph+gQZyV9Tvkh2PbidIU3nUjvBgh7ba560kEQ
         G8WqMKgampag0DHHoS6k31WXSqQcOqejz33kbSF0mToIsdMuLPYLBbhvjRrOp6w0iDJw
         t/wxST0DS3qkDPJKzHQPT5If2JpkvJO+K8M8OnRbysUyaGRRoXIR+jgQsDZM15LZdwRM
         XxXDuyTrrbBCUKoE/ouX3rl2etaGsbgsYKAcq+Ljceb35UQTtIr4C0RYTh3+tK+Vepd8
         qblA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=GWVLGd3rRWNvU7sP85NRp5wt10btcwDSd57p3ueaPIg=;
        b=V0PkdAotwWru02rOZlpkC4Je7oUKy5/7Xhhc/eS+2hLJpOAnIn0XE5uZNbrHAWV3zx
         8Mg37X+VgJ7BYd2NAWPfhBVpQI4c+L8UiaQ0YzmAnpnoKqAZRtkoHbst/iE385Tic/sr
         hDb+XpKf2Q00rGNzvL4WOHcUR+4RO3ESC8BPIRl9U3Nnj+EWisFEB0dP/bQMNw2+5oet
         5lcWqVCw9W4DSgVRAW7t53UYYbM2sxDoG069DusRvvsMyGeEc//qA8L1sYHCwS7w8B39
         QAiPln1g9Jy0jRIizADvF8OGoyZVhI1RoB5DUqJSVHUnIPWbQAt7ivfzWCblTjw8rC08
         iPsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a6sor37780227qtk.58.2019.04.08.19.44.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 19:44:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyA+PmYoJsgVkbSjy9sMazqV1hbg1cOyBmP6u5iAlIm/HSoNFnjKe4pAk1znbUJVzee8rnXlw==
X-Received: by 2002:ac8:184b:: with SMTP id n11mr28387822qtk.210.1554777868868;
        Mon, 08 Apr 2019 19:44:28 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id n188sm17572320qkb.40.2019.04.08.19.44.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 08 Apr 2019 19:44:27 -0700 (PDT)
Date: Mon, 8 Apr 2019 22:44:25 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Thoughts on simple scanner approach for free page hinting
Message-ID: <20190408203541-mutt-send-email-mst@kernel.org>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 05, 2019 at 05:09:45PM -0700, Alexander Duyck wrote:
> In addition we will need some way to identify which pages have been
> hinted on and which have not. The way I believe easiest to do this
> would be to overload the PageType value so that we could essentially
> have two values for "Buddy" pages. We would have our standard "Buddy"
> pages, and "Buddy" pages that also have the "Offline" value set in the
> PageType field. Tracking the Online vs Offline pages this way would
> actually allow us to do this with almost no overhead as the mapcount
> value is already being reset to clear the "Buddy" flag so adding a
> "Offline" flag to this clearing should come at no additional cost.

It bothers me a bit that this doesn't scale to multiple hint types
if we ever need them. Would it be better to have two
free lists: hinted and non-hinted one?


-- 
MST

