Date: Fri, 1 Oct 2004 22:57:27 +0200
From: bert hubert <ahu@ds9a.nl>
Subject: Re: md hangs while rebuilding
Message-ID: <20041001205727.GA30680@outpost.ds9a.nl>
References: <1096658210.9342.1525.camel@arcane>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1096658210.9342.1525.camel@arcane>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Shesha B.  Sreenivasamurthy" <shesha@inostor.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 01, 2004 at 12:16:51PM -0700, Shesha B.  Sreenivasamurthy wrote:

> I have 9 disks raid 1. I pulled out 4 disks, and using raidhotadd I
> triggered a rebuild on 3 of them. While rebuilding md1, the rebuilding
> process is stuck at 0.0%. Below is a snapshot of "/proc/mdstat". 

Please please please tell people what kernel you run with and your exact
configuration.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
