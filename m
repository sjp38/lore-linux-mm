Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id CACCD6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 22:22:40 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id e11so130916qcx.22
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 19:22:39 -0700 (PDT)
Date: Wed, 14 Aug 2013 22:22:35 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
Message-ID: <20130815022235.GA4439@htj.dyndns.org>
References: <520BDD2F.2060909@gmail.com>
 <20130814195541.GH28628@htj.dyndns.org>
 <520BE891.8090004@gmail.com>
 <20130814203538.GK28628@htj.dyndns.org>
 <520BF3E3.5030006@gmail.com>
 <20130814213637.GO28628@htj.dyndns.org>
 <520C2A06.5020007@gmail.com>
 <20130815012133.GQ28628@htj.dyndns.org>
 <20130815013346.GR28628@htj.dyndns.org>
 <520C3273.10605@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520C3273.10605@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Tang Chen <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Wed, Aug 14, 2013 at 09:44:19PM -0400, KOSAKI Motohiro wrote:
> >This is doubly idiotic because this is all early boot.  Most users
> >don't even have a way to access the debug info if the machine crashes
> >that early.  Developement convenience is something that we consider
> >too but, seriously, users come first.  This is not your personal
> >playground.  Don't frigging crash if you have any other option.
> 
> Again, the best depend on the purpose and the goal. If someone specify
> to enable hotplugging, They are sure they need it. Now, any fallback
> achieve their goal. Their goal is not booting. If they don't have enough
> machine to achieve their goal, we have only one way, tell them that.

Yes, you go and tell them with the blank screen.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
