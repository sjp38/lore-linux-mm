Message-ID: <4845DC72.5080206@firstfloor.org>
Date: Wed, 04 Jun 2008 02:06:10 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
References: <20080603095956.781009952@amd.local0.net>	 <20080603100939.967775671@amd.local0.net>	 <1212515282.8505.19.camel@nimitz.home.sr71.net>	 <20080603182413.GJ20824@one.firstfloor.org>	 <1212519555.8505.33.camel@nimitz.home.sr71.net>	 <20080603205752.GK20824@one.firstfloor.org> <1212528479.7567.28.camel@nimitz.home.sr71.net>
In-Reply-To: <1212528479.7567.28.camel@nimitz.home.sr71.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: npiggin@suse.de, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

> Also, as I said, users doesn't really know what the OS or hardware will
> support 

The normal Linux expectation is that these kinds of users will not
use huge pages at all.  Or rather if everybody was supposed to use
them then all the interfaces would need to be greatly improved and any
kinds of boot parameters would be out and they would need to be
100% integrated with the standard VM.

Hugepages are strictly an harder-to-use optimization for specific people
who love to tweak (e.g. database administrators or benchmarkers). From
what I heard so far these people like to have more control, not less.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
