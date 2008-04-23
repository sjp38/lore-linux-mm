Message-ID: <480EEDD9.2010601@firstfloor.org>
Date: Wed, 23 Apr 2008 10:05:45 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [patch 00/18] multi size, and giant hugetlb page support, 1GB
 hugetlb for x86
References: <20080423015302.745723000@nick.local0.net>
In-Reply-To: <20080423015302.745723000@nick.local0.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> Testing-wise, I've changed the registration mechanism so that if you specify
> hugepagesz=1G on the command line, then you do not get the 2M pages by default
> (you have to also specify hugepagesz=2M). Also, when only one hstate is
> registered, all the proc outputs appear unchanged, so this makes it very easy
> to test with.

Are you sure that's a good idea? Just replacing the 2M count in meminfo
with 1G pages is not fully compatible proc ABI wise I think.

I think rather that applications who only know about 2M pages should
see "0" in this case and not be confused by larger pages. And only
applications who are multi page size aware should see the new page
sizes.

If you prefer it you could move all the new page sizes to sysfs
and only ever display the "legacy page size" in meminfo,
but frankly I personally prefer the quite simple and comparatively
efficient /proc/meminfo with multiple numbers interface.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
