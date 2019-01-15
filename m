Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1DC4C43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 07:38:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55C5F20859
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 07:38:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mU/O8YQC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55C5F20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 029638E0003; Tue, 15 Jan 2019 02:38:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1BC48E0002; Tue, 15 Jan 2019 02:38:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0C248E0003; Tue, 15 Jan 2019 02:38:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B55A18E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:38:45 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id d63so1375784iog.4
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 23:38:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lVehsSeMWUU3jkTxsZPIrdSDz5kPYi5V6dHdpqfENcA=;
        b=JAvq1JFQ3J+AaeDBJk91crpS3U3Vf7wA64d6o5CA5h6WhHsd/YJfAVhAresR/iASgg
         pwtvejNFrLwEYeEtVWyAFIB22M5w/wgCQcityfjwZKTGEezXw9NatE4LsH8jY0b7/bry
         2NXIUXn0Ktx8LxGA0jZXG4LDa/fYwW7jWUqfC4LXMgFulV8eqZ1c+3a0OXRTZfhChUMk
         pYOXxrxWTYeZzET00AiZPHmRj0ALb78504mG0toqpZ8UFWyYPAbOO+u4ZIr7E8QK2Pvh
         15hnBsh+xXu4m3yQkv8MRcmKJhX7v2FM9X73O5QFNOzo4ws6W4aPj1Xy7eO8Sc5z2Z6j
         HWKA==
X-Gm-Message-State: AJcUukcxMpmEgtfGAK5FQTWLcHIY8KJ2A+KqcS+o8nUecmWDlS2O2UQP
	eJQyD9kWSuREvjSO6tQjY82c+Pe2hQ/pt19WNz5xRL+x6Vr1lWXD0zD8HLeUnh/f0f5PTjmD/Qz
	XJvl/bmAxQtPyZNYLw6l37i4JVV4J7fJGZijiChMphZuhNB1vYZCXgbY9XMdcGY1e51ByYhiSKa
	AclLiUL1azERlKhdZU978GrQiKZZZ/nBMAQQgNjvYfGwLhiX3O0L5jXPQ2hrnNVOFqdMGFbgLkg
	N2pKEjDtrngvYUQ0h90Q7D5sgPcdi9PK+kGfi7yL0Yjt/AnuoeYpnr9UymPQ5A+RJCO5SRLJ9pr
	MtagZuq08u9aCTAi6GE5dxrSaX/a2Oco6fei4ay4ldvhY7nNQO9ek5G1WXXfAk+fzdD+qywFVGg
	b
X-Received: by 2002:a24:3752:: with SMTP id r79mr1492337itr.121.1547537925480;
        Mon, 14 Jan 2019 23:38:45 -0800 (PST)
X-Received: by 2002:a24:3752:: with SMTP id r79mr1492320itr.121.1547537924696;
        Mon, 14 Jan 2019 23:38:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547537924; cv=none;
        d=google.com; s=arc-20160816;
        b=lF9Cb6mo0undGHRM4CxgVjYX3zQuIbXfBWIr/DD/3VGBEfpbYs4BZaNPkXvbSZ/RDY
         JZo/i0+0eZXFE52jOWDNnUV1OYUgB36RWvYqby1oqPBznrqxU+WBFegzNR6OYbrzSOwv
         RDyjYg3e700v6RL2pHHaAVydwFTtXM7uYxUpUu1gotUdYCy7uJeGqh9nBLCwTSVJDFmx
         RA2g7wcWovUtcrdRzzyJxAiBljeQ2NSlJCCcxHG089LI7/5Dm/2A9YBCLYGOVOvBm57z
         IXQ1kmnJIwMUEs8JE34MdQubPaDO7wbsLWwM3FRW6kL1M/IgmJhN5BYXr9klIjGPwnSO
         PlMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lVehsSeMWUU3jkTxsZPIrdSDz5kPYi5V6dHdpqfENcA=;
        b=vdhqxYmcVrXMlLPktH1eFWbcBcqxQcgijiOEg/bz4zlTt5AVdtCx0mGW7856YnPreN
         2YHb7LLq6y3so2bd3RdhP+X70WCfAWUKUdTgMNcMuyV8Q1EHQ7fcxta3YR2QVs77vZA/
         RX84VxZCLM048ADeXNSfbQSC71wdcLxJC8lH6QnQxHW7BB6J4sI5mhEN93XsJCMm9LhX
         3a8ksnGPGe32U9sI+ZvwsmHzKkbLtHNbyKMFBmsaWGB0grpaBsCodZcm6jOERtAVfVDZ
         aJeUaacYwiwhZ2TPh7tAhcZghz35Ef93FXbO7DZGeFH2D0v0mOJSMi+wib2+78YM676z
         BkGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="mU/O8YQC";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor1331810ioh.73.2019.01.14.23.38.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 23:38:44 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="mU/O8YQC";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lVehsSeMWUU3jkTxsZPIrdSDz5kPYi5V6dHdpqfENcA=;
        b=mU/O8YQCDCXkh1/jmyk2APkT52zILHjHehkY+lUIOM3mBlCmm1A+gbSQuSGnhijgBL
         zzuu4SH4zZ3rU90KKhQrAYkcRNogpzp2LzgbpxSFIv6xFfRokvtR4DR7VOtnVS1+VRcB
         fzncpIZggKL9GqtXA0EO2l+nzIYKSFfxYJ0kISupD60wtWXAsvLg1SlXjuTjdpEKvL0y
         oZwYdoViinuxpaX5LCcXsl5DM5QGR4ocvwuV0tikJqr9ntyt4Mk9/Js5DWkvFTMij1ss
         3pQ9h8amEBzEIJK98cIatCBi3guVvFmcbcM0KYPHGhj2SZARhQnpqWho4AhBIqIxCV2n
         PePQ==
X-Google-Smtp-Source: ALg8bN7OGtN1JqEKvyXJgs4JoqOsGxp9q81rPmOCUPwNb81kL7oXPQzVsG/lBRT6XC0tu9hkN3Vn4MG31Wb2VWuOo8Y=
X-Received: by 2002:a6b:39c6:: with SMTP id g189mr1168813ioa.255.1547537924450;
 Mon, 14 Jan 2019 23:38:44 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-7-git-send-email-kernelfans@gmail.com> <fff8c6b6-7344-7ecb-b1a8-3c49af34c892@intel.com>
In-Reply-To: <fff8c6b6-7344-7ecb-b1a8-3c49af34c892@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 15:38:33 +0800
Message-ID:
 <CAFgQCTsZOeBb8dUaq5LLfwzTObK5tT47h5U_BkfgtPDYLW9CqA@mail.gmail.com>
Subject: Re: [PATCHv2 6/7] x86/mm: remove bottom-up allocation style for x86_64
To: Dave Hansen <dave.hansen@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, 
	Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, 
	linux-acpi@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115073833.s03nCJqtK2NGAki9cBGxTbEEzSayU7tHFw1h-YlMhZs@z>

On Tue, Jan 15, 2019 at 7:27 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/10/19 9:12 PM, Pingfan Liu wrote:
> > Although kaslr-kernel can avoid to stain the movable node. [1]
>
> Can you explain what staining is, or perhaps try to use some more
> standard nomenclature?  There are exactly 0 instances of the word
> "stain" in arch/x86/ or mm/.
>
I mean that KASLR may randomly choose some positions for base address,
which are located in movable node.

> > But the
> > pgtable can still stain the movable node. That is a probability problem,
> > although low, but exist. This patch tries to make it certainty by
> > allocating pgtable on unmovable node, instead of following kernel end.
>
> Anyway, can you read my suggested summary in the earlier patch and see
> if it fits or if I missed anything?  This description is really hard to
> read.
>
Your summary in the reply to [PATCH 0/7] express the things clearly. I
will use them to update the commit log

> ...> +#ifdef CONFIG_X86_32
> > +
> > +static unsigned long min_pfn_mapped;
> > +
> >  static unsigned long __init get_new_step_size(unsigned long step_size)
> >  {
> >       /*
> > @@ -653,6 +655,32 @@ static void __init memory_map_bottom_up(unsigned long map_start,
> >       }
> >  }
> >
> > +static unsigned long __init init_range_memory_mapping32(
> > +     unsigned long r_start, unsigned long r_end)
> > +{
>
> Why is this returning a value which is not used?
>
> Did you compile this?  Didn't you get a warning that you're not
> returning a value from a function returning non-void?
>
It should be void. I will fix it in next version

> Also, I'd much rather see something like this written:
>
> static __init
> unsigned long init_range_memory_mapping32(unsigned long r_start,
>                                           unsigned long r_end)
>
> than what you have above.  But, if you get rid of the 'unsigned long',
> it will look much more sane in the first place.

Yes. Thank for your kindly review.

Best Regards,
Pingfan

