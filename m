Message-ID: <417EBFB3.5000803@kolumbus.fi>
Date: Wed, 27 Oct 2004 00:20:51 +0300
From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: 150 nonlinear
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>	 <1098815779.4861.26.camel@localhost>  <417EA06B.5040609@kolumbus.fi>	 <1098819748.5633.0.camel@localhost>  <417EB684.1060100@kolumbus.fi> <1098824141.6188.1.camel@localhost>
In-Reply-To: <1098824141.6188.1.camel@localhost>
Content-Transfer-Encoding: 8BIT
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>On Tue, 2004-10-26 at 13:41, Mika Penttila wrote:
>  
>
>>Ah, you mean Daniel Phillips's initial patch for nonlinear...
>>    
>>
>
>No.  Dan had a lovely idea, and a decent implementation, but Dave M
>completely reimplemented it as far as I know.  That's why I've been
>referring to them as "implementations".
>
>  
>
I see ..ok.

>>Ok, so what's the mem_map split? I see Andy renamed it section_mem_map 
>>and added NONLINEAR_OPTIMISE, how's that making a difference?
>>    
>>
>
>I don't understand the question.  Why do we need to split up mem_map?
>
>  
>
I do not understand the split either..but you said :

"There are two problems that are being solved: having a sparse layout
requiring splitting up mem_map (solved by discontigmem and your
nonlinear), and supporting non-linear phys to virt relationships (Dave
M's implentation which does the mem_map split as well)."


so what's the split?

--Mika






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
