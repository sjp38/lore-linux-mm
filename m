Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 92E506B0254
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:58:54 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so18072772pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:58:54 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id r3si4928025pap.0.2015.09.22.12.58.53
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 12:58:53 -0700 (PDT)
Subject: Re: [PATCH 05/26] x86, pkey: add PKRU xsave fields and data
 structure(s)
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174905.0ECA529B@viggo.jf.intel.com>
 <alpine.DEB.2.11.1509222152300.5606@nanos>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5601B2F9.3030906@sr71.net>
Date: Tue, 22 Sep 2015 12:58:49 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509222152300.5606@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/22/2015 12:53 PM, Thomas Gleixner wrote:
> On Wed, 16 Sep 2015, Dave Hansen wrote:
>> --- a/arch/x86/kernel/fpu/xstate.c~pkeys-03-xsave	2015-09-16 10:48:13.340060126 -0700
>> +++ b/arch/x86/kernel/fpu/xstate.c	2015-09-16 10:48:13.344060307 -0700
>> @@ -23,6 +23,8 @@ static const char *xfeature_names[] =
>>  	"AVX-512 opmask"		,
>>  	"AVX-512 Hi256"			,
>>  	"AVX-512 ZMM_Hi256"		,
>> +	"unknown xstate feature (8)"	,
> 
> It's not unknown. It's PT, right?

Yes, it's the Processor Trace state.

I'll give it a real name and also a comment about it being unused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
