Date: Wed, 11 Oct 2000 22:31:38 -0600
From: Cort Dougan <cort@fsmlabs.com>
Subject: Re: [RFC] atomic pte updates for x86 smp
Message-ID: <20001011223138.B962@hq.fsmlabs.com>
References: <Pine.LNX.3.96.1001011232450.23223A-100000@kanga.kvack.org> <200010120406.VAA07624@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200010120406.VAA07624@pizda.ninka.net>; from David S. Miller on Wed, Oct 11, 2000 at 09:06:45PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: blah@kvack.org, torvalds@transmeta.com, tytso@mit.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

}    Date: 	Thu, 12 Oct 2000 00:03:31 -0400 (EDT)
}    From: "Benjamin C.R. LaHaise" <blah@kvack.org>
} 
}    It's safe because of how x86s hardware works
} 
} What about other platforms?

On the PPC's that don't do a hardware walk we do a normal write to the
hash table (with a spinlock).  On the hardware walk PPC's I'm told this is
done with with a lwarx/stwcx pair (conditional load/store on exclusive
access).

Any comments on how this would affect PPC?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
