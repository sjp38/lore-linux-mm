Message-ID: <45B8D5AB.8040803@redhat.com>
Date: Thu, 25 Jan 2007 11:07:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com> <45B75208.90208@linux.vnet.ibm.com> <Pine.LNX.4.64.0701240655400.9696@schroedinger.engr.sgi.com> <45B82F41.9040705@linux.vnet.ibm.com> <45B835FE.6030107@redhat.com> <45B844E3.4050203@linux.vnet.ibm.com>
In-Reply-To: <45B844E3.4050203@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Aubrey Li <aubreylee@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Vaidyanathan Srinivasan wrote:
> Rik van Riel wrote:

>> There are a few databases out there that mmap the whole
>> thing.  Sleepycat for one...
> 
> That is why my suggestion would be not to touch mmapped pagecache
> pages in the current pagecache limit code.  The limit should concern
> only unmapped pagecache pages.

So you want to limit how much data the kernel caches for mysql
or postgresql, but not limit how much of the rpm database is
cached ?!

IMHO your proposal does the exact opposite of what would be
right for my systems :)

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
