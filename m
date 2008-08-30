Date: Sat, 30 Aug 2008 14:19:08 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: oom-killer why ?
Message-ID: <20080830141908.2fdf788b@bree.surriel.com>
In-Reply-To: <48B4F268.20901@iplabs.de>
References: <48B296C3.6030706@iplabs.de>
	<48B3E4CC.9060309@linux.vnet.ibm.com>
	<48B3F04B.9030308@iplabs.de>
	<48B401F8.9010703@linux.vnet.ibm.com>
	<48B402B1.8030902@linux.vnet.ibm.com>
	<1219777788.24829.53.camel@dhcp-100-19-198.bos.redhat.com>
	<48B4BCAE.7000906@linux.vnet.ibm.com>
	<48B4F268.20901@iplabs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Nietz <m.nietz-mm@iplabs.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Aug 2008 08:21:28 +0200
Marco Nietz <m.nietz-mm@iplabs.de> wrote:

> My first guess that the oom where caused by running out of Lowmem was
> confirmed and the Solution is to upgrade the Server to a 64bit OS.

Indeed.
 
> All right to that point, but why this was affected by the raised up
> Sharded Buffers from postgres ? Is shared buffer preferred to be in lowmem ?
> 
> With the smaller Buffersize (256mb) we haven't had any Problems with
> that Machine.

No, but the page tables used to map the shared buffer are in lowmem.

Page tables take up 0.5% of the data size, per process.

This means that if you have 200 processes mapping 1GB of data, you
would need 1GB of page tables.  You do not have that much lowmem :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
