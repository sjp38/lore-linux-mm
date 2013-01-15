Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5D8F88D0001
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 19:14:54 -0500 (EST)
Message-ID: <1358208301.14145.118.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 14 Jan 2013 17:05:01 -0700
In-Reply-To: <20130114143456.3962f3bd.akpm@linux-foundation.org>
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>
	 <50F440F5.3030006@zytor.com>
	 <20130114143456.3962f3bd.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Tang Chen <tangchen@cn.fujitsu.com>, jiang.liu@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2013-01-14 at 14:34 -0800, Andrew Morton wrote:
> On Mon, 14 Jan 2013 09:31:33 -0800
> "H. Peter Anvin" <hpa@zytor.com> wrote:
> 
> > On 01/14/2013 01:15 AM, Tang Chen wrote:
> > >
> > > For now, users can disable this functionality by not specifying the boot option.
> > > Later, we will post SRAT support, and add another option value "movablecore_map=acpi"
> > > to using SRAT.
> > >
> > 
> > I still think the option "movablecore_map" is uglier than hell.  "core" 
> > could just as easily refer to CPU cores there, but it is a memory mem. 
> > "movablemem" seems more appropriate.
> > 
> > Again, without SRAT I consider this patchset to be largely useless for 
> > anything other than prototyping work.
> > 
> 
> hm, why.  Obviously SRAT support will improve things, but is it
> actually unusable/unuseful with the command line configuration?

I think it is useful for prototyping and testing.  I do not think it is
suitable for regular users.

> Also, "But even if we can use SRAT, users still need an interface to
> enable/disable this functionality if they don't want to loose their
> NUMA performance.  So I think, an user interface is always needed."

Yes, but such user interface could be provided through the management
interface (GUI/CLI) of the platforms (or VMs).  If user sets for
performance, SRAT could be generated with no hot-pluggable memory.  If
user sets node N to be hot-removable, SRAT could be generated in such
way that all memory ranges in node N are hot-pluggable.

Thanks,
-Toshi


> There's also the matter of other architectures.  Has any thought been
> given to how (eg) powerpc would hook into here?
> 
> And what about VMs (xen, KVM)?  I wonder if there is a case for those
> to implement memory hotplug.  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
