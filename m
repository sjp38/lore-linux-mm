Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02B476B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 09:31:50 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o187so1980959qke.1
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 06:31:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f65si4776748qkj.405.2017.11.03.06.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 06:31:48 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA3DU2wJ048561
	for <linux-mm@kvack.org>; Fri, 3 Nov 2017 09:31:47 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e0p7e3v7a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Nov 2017 09:31:47 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 3 Nov 2017 13:31:44 -0000
Date: Fri, 3 Nov 2017 14:31:37 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 0/3] lsmem/chmem: add memory zone awareness
In-Reply-To: <20171103101104.kw6xoxust3r7f7v3@ws.net.home>
References: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
	<20171018114009.7b4iax6536un5bnr@ws.net.home>
	<20171102175408.18d4eafc@thinkpad>
	<20171103101104.kw6xoxust3r7f7v3@ws.net.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20171103143137.35c41e7f@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Karel Zak <kzak@redhat.com>
Cc: util-linux@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andre Wild <wild@linux.vnet.ibm.com>

On Fri, 3 Nov 2017 11:11:04 +0100
Karel Zak <kzak@redhat.com> wrote:

> On Thu, Nov 02, 2017 at 05:54:08PM +0100, Gerald Schaefer wrote:
> > Sorry for the late answer. I'm not sure if I understand the problem, it
> > "works as designed" that the range merging is done based on the output
> > columns, but I see that it was not really described as such. So I do
> > like the note that you added with the above mentioned commit.
> > 
> > However, regarding the --split option, I think it may be confusing at
> > least for human users, if an "lsmem -oRANGE" will now print more than
> > one range, even if this is now based on a "fixed" set of default columns
> > that are used for merging (but "subject to change" according to the man
> > page).  
> 
> OK, I think we can support both concepts :-) I have modified lsmem to:
> 
>  - follow output columns for split policy by default (= your original implementation)
>  - the --split is optional and may be used to override the default behavior
> 
> it means for humans it's probably less concussing and advanced users may
> define by --split another way how to generate the ranges.
> 
> I think it's good compromise and it's backwardly compatible with
> the previous version. OK?

Yes, that looks good.

> 
> If yes, I need to backport this change to RHEL7.5 :-)
> 

Yes, please :-)


> > I also do not really see the benefit for script usage, at least if we
> > define it as "expected behavior" to have the ranges merged based on the  
> 
> We want to keep it user friendly. The "expected behavior" (now
> default) forces you to parse lsmem output to filter out unnecessary 
> columns (if you care about RANGE only). 
> 
> And in all our utils the --output option really control the output, but 
> no another behavior.

OK, that makes sense. I did not have any output selection in the original
implementation, and also no focus on script usage, but as (maybe so far
the only) human user I did get confused by the new range merging.

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
