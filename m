From: "LA Walsh" <law@sgi.com>
Subject: RE: address_space: Theory of operation?
Date: Tue, 6 Feb 2001 07:52:55 -0800
Message-ID: <NBBBJGOOMDFADJDGDCPHKEDPCKAA.law@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20010206134821.Q849@nightmaster.csn.tu-chemnitz.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Also, more widely, any of the new op fields the blk ops, the new inode
fields,
getattr/setattr, etc...descriptions would be "real keen"....:-)

> -----Original Message-----
> From: linux-fsdevel-owner@vger.kernel.org
> [mailto:linux-fsdevel-owner@vger.kernel.org]On Behalf Of Ingo Oeser
> Sent: Tuesday, February 06, 2001 4:48 AM
> To: linux-fsdevel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Subject: address_space: Theory of operation?
>
>
> Hi there,
>
> is there any description of what address_space is supposed to to?
>
> What are the address_space_operations expected to handle?
>
> Sure, I could look into the sources to find out (and I did
> already), but how could I distinguish between a proper
> implementation and a BUG?
>
> I searched the archives already (but using address_space as
> primary keyword, so I wouldn't get renames) without any luck.
>
> So could somebody please point me to some documentation about it
> or comment it, if there is none?
>
> Many thanks!
>
> Regards
>
> Ingo Oeser
> --
> 10.+11.03.2001 - 3. Chemnitzer LinuxTag
<http://www.tu-chemnitz.de/linux/tag>
         <<<<<<<<<<<<       come and join the fun       >>>>>>>>>>>>
-
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
the body of a message to majordomo@vger.kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
