Subject: Re: [Lhms-devel] Re: 150 nonlinear
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <417EC7E7.5040004@kolumbus.fi>
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>
	 <1098815779.4861.26.camel@localhost>  <417EA06B.5040609@kolumbus.fi>
	 <1098819748.5633.0.camel@localhost>  <417EB684.1060100@kolumbus.fi>
	 <1098824141.6188.1.camel@localhost>  <417EBFB3.5000803@kolumbus.fi>
	 <1098826023.7172.4.camel@localhost>  <417EC3E9.5020406@kolumbus.fi>
	 <1098826917.7172.31.camel@localhost>  <417EC7E7.5040004@kolumbus.fi>
Content-Type: text/plain; charset=ISO-8859-1
Message-Id: <1098827619.7172.47.camel@localhost>
Mime-Version: 1.0
Date: Tue, 26 Oct 2004 14:53:39 -0700
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-26 at 14:55, Mika Penttila wrote:
> Andy:         __pa and __va as before, nonlinear page_to_pfn and pfn_to_page
> Dave M :     new nonlinear __pa and __va implementations and nonlinear 
> page_to_pfn and pfn_to_page

Yes, basically.  Those are the most visible high-level-API functions
that get changed.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
