Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id D96856B0002
	for <linux-mm@kvack.org>; Wed, 22 May 2013 19:20:52 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] Driver core / memory: Simplify __memory_block_change_state()
Date: Thu, 23 May 2013 01:29:36 +0200
Message-ID: <2523424.su5lDNaCQ2@vostro.rjw.lan>
In-Reply-To: <20130522221443.GA7427@kroah.com>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan> <1594596.DcsjzgnrZI@vostro.rjw.lan> <20130522221443.GA7427@kroah.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, vasilis.liaskovitis@profitbricks.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org

On Wednesday, May 22, 2013 03:14:43 PM Greg Kroah-Hartman wrote:
> On Thu, May 23, 2013 at 12:06:50AM +0200, Rafael J. Wysocki wrote:
> > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > 
> > As noted by Tang Chen, the last_online field in struct memory_block
> > introduced by commit 4960e05 (Driver core: Introduce offline/online
> > callbacks for memory blocks) is not really necessary, because
> > online_pages() restores the previous state if passed ONLINE_KEEP as
> > the last argument.  Therefore, remove that field along with the code
> > referring to it.
> > 
> > References: http://marc.info/?l=linux-kernel&m=136919777305599&w=2
> > Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> 
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
