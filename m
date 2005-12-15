Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: 2.6.15-rc5-mm2 can't boot on ia64 due to changing on_each_cpu().
Date: Thu, 15 Dec 2005 09:24:03 -0800
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F0535A4DC@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, Dec 15, 2005 at 02:24:29PM +0900, Kenji Kaneshige wrote:
> > How about this?
> 
> Excellent!  Thanks Kenji.  Tony, are you okay with this patch going in?

It is a bit annoying to have to add an argument that is never
used to local_flush_tlb_all() just to make the compiler make
the right code when we want to use in with on_each_cpu().  But
I don't see a better way.

Acked-by: Tony Luck <tony.luck@intel.com>

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
