From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] vmalloc: Add __get_vm_area_caller()
Date: Thu, 12 Feb 2009 11:11:04 +1100
Message-ID: <1234397464.29851.20.camel__26713.3249938071$1234397598$gmane$org@pasglop>
References: <20090211044854.969CEDDDA9@ozlabs.org>
	 <20090211171804.7021.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090211144509.d22feeb8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757025AbZBLALg@vger.kernel.org>
In-Reply-To: <20090211144509.d22feeb8.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Wed, 2009-02-11 at 14:45 -0800, Andrew Morton wrote:
> On Wed, 11 Feb 2009 17:22:47 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > I want to put into powerpc-next patches relying into that, so if the
> > > patch is ok with you guys, can I stick it in powerpc.git ?
> > 
> > hm.
> > Generally, all MM patch should merge into -mm tree at first.
> > but I don't think this patch have conflict risk. 
> > 
> > Andrew, What do you think?
> 
> We can sneak it into mainline later in the week?

That would be best.

Cheers,
Ben.
