Message-ID: <417EC954.8040700@kolumbus.fi>
Date: Wed, 27 Oct 2004 01:01:56 +0300
From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: 150 nonlinear
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>	 <1098815779.4861.26.camel@localhost>  <417EA06B.5040609@kolumbus.fi>	 <1098819748.5633.0.camel@localhost>  <417EB684.1060100@kolumbus.fi>	 <1098824141.6188.1.camel@localhost>  <417EBFB3.5000803@kolumbus.fi>	 <1098826023.7172.4.camel@localhost>  <417EC3E9.5020406@kolumbus.fi>	 <1098826917.7172.31.camel@localhost>  <417EC7E7.5040004@kolumbus.fi> <1098827619.7172.47.camel@localhost>
In-Reply-To: <1098827619.7172.47.camel@localhost>
Content-Transfer-Encoding: 8BIT
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>On Tue, 2004-10-26 at 14:55, Mika Penttila wrote:
>  
>
>>Andy:         __pa and __va as before, nonlinear page_to_pfn and pfn_to_page
>>Dave M :     new nonlinear __pa and __va implementations and nonlinear 
>>page_to_pfn and pfn_to_page
>>    
>>
>
>Yes, basically.  Those are the most visible high-level-API functions
>that get changed.
>
>-- Dave
>
>  
>
great..thanks!

--Mika


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
