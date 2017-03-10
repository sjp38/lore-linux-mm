Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18A896B0395
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 17:00:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id o126so185291409pfb.2
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 14:00:46 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v185si4133422pgv.305.2017.03.10.14.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 14:00:45 -0800 (PST)
Date: Fri, 10 Mar 2017 23:00:20 +0100
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170310220020.GH6346@olila.local.net-space.pl>
References: <20170227154304.GK26504@dhcp22.suse.cz>
 <1488462828-174523-1-git-send-email-imammedo@redhat.com>
 <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306145417.GG27953@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz

Hey,

On Mon, Mar 06, 2017 at 03:54:17PM +0100, Michal Hocko wrote:

[...]

> So let's discuss the current memory hotplug shortcomings and get rid of
> the crud which developed on top. I will start by splitting up the patch
> into 3 parts. Do the auto online thing from the HyperV and xen balloning
> drivers and dropping the config option and finally drop the sysfs knob.
> The last patch might be NAKed and I can live with that as long as the
> reasoning is proper and there is a general consensus on that.

If it is not too late please CC me on the patches and relevant threads.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
