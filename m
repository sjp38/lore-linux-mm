Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 59BF66B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 14:17:50 -0400 (EDT)
From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Fri, 21 May 2010 11:17:51 -0700
Subject: RE: [PATCH] slub: move kmem_cache_node into it's own cacheline
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F256284AECC@orsmsx501.amr.corp.intel.com>
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com>
 <alpine.DEB.2.00.1005211305340.14851@router.home>
In-Reply-To: <alpine.DEB.2.00.1005211305340.14851@router.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 20 May 2010, Alexander Duyck wrote:
>=20
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>> index 0249d41..e6217bb 100644 --- a/include/linux/slub_def.h
>> +++ b/include/linux/slub_def.h
>> @@ -52,7 +52,7 @@ struct kmem_cache_node {
>>  	atomic_long_t total_objects;
>>  	struct list_head full;
>>  #endif
>> -};
>> +} ____cacheline_internodealigned_in_smp;
>=20
> What does this do? Leftovers?

It aligns it to the correct size so that no two instances can occupy a shar=
ed cacheline.  I put that in place to avoid any false sharing of the object=
s should they fit into a shared cacheline on a NUMA system.

Thanks,

Alex=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
