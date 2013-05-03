Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 534506B02E1
	for <linux-mm@kvack.org>; Fri,  3 May 2013 12:16:20 -0400 (EDT)
Date: Fri, 3 May 2013 16:16:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
In-Reply-To: <20130503153450.GA18709@dhcp22.suse.cz>
Message-ID: <0000013e6b2e06ab-a26ffcc5-a52d-4165-9be0-025ae813da00-000000@email.amazonses.com>
References: <0000013e427023d7-9456c313-8654-420c-b85a-cb79cc3c4ffc-000000@email.amazonses.com> <20130426062436.GB4441@localhost.localdomain> <0000013e46cba821-d5c54c99-3b5c-4669-9a54-9fb8f4ee516f-000000@email.amazonses.com> <20130427112418.GC4441@localhost.localdomain>
 <0000013e5645b356-09aa6796-0a95-40f1-8ec5-6e2e3d0c434f-000000@email.amazonses.com> <20130429145711.GC1172@dhcp22.suse.cz> <20130502105637.GD4441@localhost.localdomain> <0000013e65cb32b3-047cd2d6-dfc8-41d2-a792-9b398f9a1baf-000000@email.amazonses.com>
 <20130503030345.GE4441@localhost.localdomain> <0000013e6aff6f95-b8fa366e-51a5-4632-962e-1b990520f5a8-000000@email.amazonses.com> <20130503153450.GA18709@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Fri, 3 May 2013, Michal Hocko wrote:

> > Both should be fixed.
>
> Could you point to the specific commit(s), please?
>
> > Making requests for large amounts of memory from an allocator that is
> > supposed to hand out fraction of a page does not make sense.
>
> AFAIR there were lots of objects in size-512 as well.

Looks like I have confused two different issues here. Sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
