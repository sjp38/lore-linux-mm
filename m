Message-ID: <39621DAD.BBC4A89D@norran.net>
Date: Tue, 04 Jul 2000 19:23:57 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: 2.4.0-test3-pre2: corruption in mm?
References: <3961A761.974CED49@norran.net> <m28zvh50oc.fsf@boreas.southchinaseas>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

John Fremlin wrote:
> 
> Roger Larsson <roger.larsson@norran.net> writes:
> 
> > When I booted up today mount complained that one of my disks
> > was not ok. (/usr)
> 
> I had ext2fs corruption (plain 2.4.0-test2) when installing a new
> sendmail. (Which is why I'm not testing out any VM patches on test2,
> sorry Roger). One of the man page's got a lot of really wacky block
> numbers when installed. The first part was there but trying to read
> the tail got:
> 

Avoid 2.4.0-test2 since it has KNOWN corruption problems...
2.4.0-test3 should not... this report was about test3
Corrupted files will(?) remain from test2 when upgrading to test3

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
