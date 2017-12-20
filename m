Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D04E6B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 11:01:03 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id y127so667852vkg.17
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 08:01:03 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id o1si961614vkd.309.2017.12.20.08.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 08:01:02 -0800 (PST)
Date: Wed, 20 Dec 2017 09:58:30 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 4/5] mm: use node_page_state_snapshot to avoid
 deviation
In-Reply-To: <1f3a6d05-2756-93fd-a380-df808c94ece8@intel.com>
Message-ID: <alpine.DEB.2.20.1712200956080.7506@nuc-kabylake>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com> <1513665566-4465-5-git-send-email-kemi.wang@intel.com> <20171219124317.GP2787@dhcp22.suse.cz> <94187fd5-ad70-eba7-2724-0fe5bed750d6@intel.com> <20171220100650.GI4831@dhcp22.suse.cz>
 <1f3a6d05-2756-93fd-a380-df808c94ece8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Wed, 20 Dec 2017, kemi wrote:

> > You are making numastats special and I yet haven't heard any sounds
> > arguments for that. But that should be discussed in the respective
> > patch.
> >
>
> That is because we have much larger threshold size for NUMA counters, that means larger
> deviation. So, the number in local cpus may not be simply ignored.

Some numbers showing the effect of these changes would be helpful. You can
probably create some in kernel synthetic tests to start with which would
allow you to see any significant effects of those changes.

Then run the larger testsuites (f.e. those that Mel has published) and
benchmarks to figure out how behavior of real apps *may* change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
