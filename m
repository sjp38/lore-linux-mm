Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 182A46B00EC
	for <linux-mm@kvack.org>; Mon,  6 May 2013 15:38:38 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 2/2 v2, RFC] Driver core: Introduce offline/online callbacks for memory blocks
Date: Mon, 06 May 2013 21:46:59 +0200
Message-ID: <7557979.vTGLb3exlI@vostro.rjw.lan>
In-Reply-To: <20130506172044.GA13974@kroah.com>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan> <19540491.PRsM4lKIYM@vostro.rjw.lan> <20130506172044.GA13974@kroah.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, vasilis.liaskovitis@profitbricks.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org

On Monday, May 06, 2013 10:20:44 AM Greg Kroah-Hartman wrote:
> On Sat, May 04, 2013 at 01:21:16PM +0200, Rafael J. Wysocki wrote:
> > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > 
> > Introduce .offline() and .online() callbacks for memory_subsys
> > that will allow the generic device_offline() and device_online()
> > to be used with device objects representing memory blocks.  That,
> > in turn, allows the ACPI subsystem to use device_offline() to put
> > removable memory blocks offline, if possible, before removing
> > memory modules holding them.
> > 
> > The 'online' sysfs attribute of memory block devices will attempt to
> > put them offline if 0 is written to it and will attempt to apply the
> > previously used online type when onlining them (i.e. when 1 is
> > written to it).
> > 
> > Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > ---
> >  drivers/base/memory.c  |  105 +++++++++++++++++++++++++++++++++++++------------
> >  include/linux/memory.h |    1 
> >  2 files changed, 81 insertions(+), 25 deletions(-)
> 
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
