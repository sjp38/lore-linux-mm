Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 60B9C6B0263
	for <linux-mm@kvack.org>; Thu,  2 May 2013 11:10:17 -0400 (EDT)
Date: Thu, 2 May 2013 15:10:15 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
In-Reply-To: <20130502105637.GD4441@localhost.localdomain>
Message-ID: <0000013e65cb32b3-047cd2d6-dfc8-41d2-a792-9b398f9a1baf-000000@email.amazonses.com>
References: <20130424044848.GI2672@localhost.localdomain> <20130424094732.GB31960@dhcp22.suse.cz> <0000013e3cb0340d-00f360e3-076b-478e-b94c-ddd4476196ce-000000@email.amazonses.com> <20130425060705.GK2672@localhost.localdomain>
 <0000013e427023d7-9456c313-8654-420c-b85a-cb79cc3c4ffc-000000@email.amazonses.com> <20130426062436.GB4441@localhost.localdomain> <0000013e46cba821-d5c54c99-3b5c-4669-9a54-9fb8f4ee516f-000000@email.amazonses.com> <20130427112418.GC4441@localhost.localdomain>
 <0000013e5645b356-09aa6796-0a95-40f1-8ec5-6e2e3d0c434f-000000@email.amazonses.com> <20130429145711.GC1172@dhcp22.suse.cz> <20130502105637.GD4441@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Han Pingtian <hanpt@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Thu, 2 May 2013, Han Pingtian wrote:

> Looks like "ibmvscsi" + "slub" can trigger this problem.

And the next merge of the slab-next tree will also cause SLAB to trigger
this issue. I would like to have this fixes. The slab allocator purpose is
to servr objects that are a fraction of a page and not objects that are
larger than the maximum allowed sizes of the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
