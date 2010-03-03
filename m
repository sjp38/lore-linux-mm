Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E31B86B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 20:43:28 -0500 (EST)
Date: Wed, 3 Mar 2010 09:43:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] nfs: use 4*rsize readahead size
Message-ID: <20100303014324.GA6477@localhost>
References: <20100224024100.GA17048@localhost> <20100224032934.GF16175@discord.disaster> <20100224041822.GB27459@localhost> <20100224052215.GH16175@discord.disaster> <20100224061247.GA8421@localhost> <20100224073940.GJ16175@discord.disaster> <20100226074916.GA8545@localhost> <20100302031021.GA14267@localhost> <dda83e781003021214g6721c142o7c66f409296cf5a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dda83e781003021214g6721c142o7c66f409296cf5a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bret Towe <magnade@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 03, 2010 at 04:14:33AM +0800, Bret Towe wrote:

> how do you determine which bdi to use? I skimmed thru
> the filesystem in /sys and didn't see anything that says which is what

MOUNTPOINT=" /mnt/ext4_test "
# grep "$MOUNTPOINT" /proc/$$/mountinfo|awk  '{print $3}'
0:24

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
