Message-ID: <45B82FAB.9040205@redhat.com>
Date: Wed, 24 Jan 2007 23:18:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> This is a patch using some of Aubrey's work plugging it in what is IMHO 
> the right way. Feel free to improve on it. I have gotten repeatedly 
> requests to be able to limit the pagecache. 

IMHO it's a bad hack.

It would be better to identify the problem this "feature" is
trying to fix, and then fix the root cause.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
