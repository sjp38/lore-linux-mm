Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA27469
	for <linux-mm@kvack.org>; Mon, 15 Jun 1998 12:57:45 -0400
Received: from boole.suse.de (Boole.suse.de [192.168.102.7])
	by Galois.suse.de (8.8.8/8.8.8) with ESMTP id SAA21737
	for <linux-mm@kvack.org>; Mon, 15 Jun 1998 18:56:48 +0200
Message-ID: <19980615185647.50925@boole.suse.de>
Date: Mon, 15 Jun 1998 18:56:47 +0200
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: TODO list, v0.01
References: <Pine.LNX.3.95.980611235823.21729A-100000@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.980611235823.21729A-100000@localhost>; from Rik van Riel on Thu, Jun 11, 1998 at 11:59:45PM +0200
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 1998 at 11:59:45PM +0200, Rik van Riel wrote:
> 
> here's the MM TODO list, very first version, just listing
> the projects people are working on.
> 
> Other projects are yet to be added -- what ones?
> 
> Rik.

[...]

> 
> Werner Fink <werner@suse.de>
> 
> 	???
> 

??? == We should get a better recover time/behaviour of the mm for small
       systems under high load.  Currently small systems with 2.1.10X
       (RAM < 32MB, sometimes < 64MB) do loose in comparision to 2.0.33/34.


          Werner
