Message-ID: <417EB684.1060100@kolumbus.fi>
Date: Tue, 26 Oct 2004 23:41:40 +0300
From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: 150 nonlinear
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>	 <1098815779.4861.26.camel@localhost>  <417EA06B.5040609@kolumbus.fi> <1098819748.5633.0.camel@localhost>
In-Reply-To: <1098819748.5633.0.camel@localhost>
Content-Transfer-Encoding: 8BIT
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>On Tue, 2004-10-26 at 12:07, Mika Penttila wrote:
>  
>
>>What do you consider as Dave M's nonlinear?
>>    
>>
>
>This, basically:
>
>http://sprucegoose.sr71.net/patches/2.6.9-rc3-mm3-mhp1/C-nonlinear-base.patch
>
>There's a little there that isn't Dave M's direct work, but it's all in
>the spirit of his implementation.
>
>-- Dave
>
>
>  
>
Ah, you mean Daniel Phillips's initial patch for nonlinear...

Ok, so what's the mem_map split? I see Andy renamed it section_mem_map 
and added NONLINEAR_OPTIMISE, how's that making a difference?

--Mika


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
