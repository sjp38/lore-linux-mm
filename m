Received: by rv-out-0708.google.com with SMTP id f25so5005544rvb.26
        for <linux-mm@kvack.org>; Mon, 28 Jul 2008 14:24:37 -0700 (PDT)
Message-ID: <86802c440807281424r73bae246va5e6afc6e2749ea7@mail.gmail.com>
Date: Mon, 28 Jul 2008 14:24:36 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: + mm-remove-find_max_pfn_with_active_regions.patch added to -mm tree
In-Reply-To: <20080728203959.GA29548@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200807280313.m6S3DHDk017400@imap1.linux-foundation.org>
	 <20080728091655.GC7965@csn.ul.ie>
	 <86802c440807280415j5605822brb8836412a5c95825@mail.gmail.com>
	 <20080728113836.GE7965@csn.ul.ie>
	 <86802c440807281125g7d424f17v4b7c512929f45367@mail.gmail.com>
	 <20080728191518.GA5352@csn.ul.ie>
	 <86802c440807281238u63770318s8e665754f666c602@mail.gmail.com>
	 <20080728200054.GB5352@csn.ul.ie>
	 <86802c440807281314k56752cdcqcac542b6f1564036@mail.gmail.com>
	 <20080728203959.GA29548@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 28, 2008 at 1:40 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On (28/07/08 13:14), Yinghai Lu didst pronounce:
>> > <SNIP>
>> >
>> > I'm not seeing what different a rename of the parameter will do. Even if
>> > the parameter was renamed, it does not mean current trace information during
>> > memory initialisation needs to be outputted as KERN_INFO which is what this
>> > patch is doing. I am still failing to understand why you want this information
>> > to be generally available.
>>
>> how about KERN_DEBUG?
>>
>> please check
>>
>
> Still NAK due to the noise. Admittedly, I introduced the noise
> in the first place but it was complained about then as well. See
> http://lkml.org/lkml/2006/11/27/124 and later this
> http://lkml.org/lkml/2006/11/27/134 .
>
> At the risk of repeating myself, I am still failing to understand why you want
> this information to be generally available at any loglevel. My expectation is
> that the information is only of relevance when debugging memory initialisation
> problems in which case mminit_loglevel can be used.

ok.
how do think about using meminit_debug to replace minit_loglevel?

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
