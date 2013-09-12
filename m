Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 047BE6B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 10:16:59 -0400 (EDT)
Date: Thu, 12 Sep 2013 14:16:58 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] mm: percpu pages: up batch size to fix arithmetic??
 errror
In-Reply-To: <523108B7.7050101@sr71.net>
Message-ID: <00000141128835e1-8664ca3a-c439-4d9d-89cb-308664595db4-000000@email.amazonses.com>
References: <20130911220859.EB8204BB@viggo.jf.intel.com> <5230F7DD.90905@linux.vnet.ibm.com> <5230FB0A.70901@linux.vnet.ibm.com> <523108B7.7050101@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 11 Sep 2013, Dave Hansen wrote:

> 3. We want ->high to approximate the size of the cache which is
>    private to a given cpu.  But, that's complicated by the L3 caches
>    and hyperthreading today.

well lets keep it well below that. There are other caches (slab related
f.e.) that are also in constant use.

> I'll take one of my big systems and run it with some various ->high
> settings and see if it makes any difference.

Do you actually see contention issues on the locks? I think we have a
tendency to batch too much in too many caches.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
