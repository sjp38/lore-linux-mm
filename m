Date: Mon, 11 Nov 2002 15:06:58 +0530 (IST)
From: <deepesh@india.tejasnetworks.com>
Subject: Cache Enabling.
Message-ID: <Pine.LNX.4.21.0211111454430.16030-100000@deepesh.india.tejasnetworks.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@suse.de, wje@cthulhu.engr.sgi.com, pongheng@starnet.gov.sg, sct@redhat.com, blah@kvack.org, clmsys@osfmail.isc.rit.edu, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, mingo@redhat.com, torvalds@transmeta.com, intermezzo-devel@stelias.com, simmonds@stelias.com
List-ID: <linux-mm.kvack.org>


Dear All,


I am using Power PC. The system which I am using takes 2 minutes more than
usual for the software in the system to come up without cache
enabling. These 2 minutes are really crucial.
But there are problems when I enabled cache. The devices which I am using
are mmapped. I do not want cache to be enabled for the memory mapped
devices. When cache is enabled, none of the mmapped devices work in the
usual way. How do I selectively disable the cache for the mmapped devices?


Thank you,
Deepesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
