From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910152232.PAA55469@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
Date: Fri, 15 Oct 1999 15:32:20 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9910151459320.852-100000@penguin.transmeta.com> from "Linus Torvalds" at Oct 15, 99 03:04:33 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: manfreds@colorfullife.com, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Okay, in the next couple of days, I will try to use the lock
currently known as "page_table_lock" for vma scan piotection
in the page stealing code and post the modififed patch.

Thanks.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
