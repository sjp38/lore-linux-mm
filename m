Subject: Re: [Lhms-devel] Re: 150 nonlinear
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <417EC3E9.5020406@kolumbus.fi>
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>
	 <1098815779.4861.26.camel@localhost>  <417EA06B.5040609@kolumbus.fi>
	 <1098819748.5633.0.camel@localhost>  <417EB684.1060100@kolumbus.fi>
	 <1098824141.6188.1.camel@localhost>  <417EBFB3.5000803@kolumbus.fi>
	 <1098826023.7172.4.camel@localhost>  <417EC3E9.5020406@kolumbus.fi>
Content-Type: text/plain; charset=ISO-8859-1
Message-Id: <1098826917.7172.31.camel@localhost>
Mime-Version: 1.0
Date: Tue, 26 Oct 2004 14:41:57 -0700
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Taking poor Andy off the cc...

On Tue, 2004-10-26 at 14:38, Mika Penttila wrote:
> Yes, I see Dave M's approarch is doing this, but isn't Andy's as well? 
> What's the key differences between these two?

Back to my first message:
>There are two problems that are being solved: having a sparse layout
>requiring splitting up mem_map (solved by discontigmem and your
>nonlinear), and supporting non-linear phys to virt relationships (Dave
>M's implentation which does the mem_map split as well).

Andy: split
Dave M: split + non-linear phys to virt

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
