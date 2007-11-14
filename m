Date: Wed, 14 Nov 2007 09:19:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Sparsemem: Do not reserve section flags if VMEMMAP is in use
Message-Id: <20071114091938.57d0f44c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0711131336500.3714@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711121944400.30269@schroedinger.engr.sgi.com>
	<20071113134603.5b4b0f24.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0711131336500.3714@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Nov 2007 13:38:11 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:
> Well that is currently not done for !SPARSEMEM configuration where 
> SECTIONS_WIDTH is also zero. So I left it as is.
> 
> > page_to_section is used in page_to_nid() if NODE_NOT_IN_PAGE_FLAGS=y.
> > (I'm not sure exact config dependency.)
> 
> NODE_NOT_IN_PAGE_FLAGS=y only occurs when flag bits are 
> taken away by sparsemem for the section bits.
> 
> 
Ahh, thank you for confirmation.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
