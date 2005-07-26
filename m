Subject: Re: Memory pressure handling with iSCSI
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
From: Roland Dreier <rolandd@cisco.com>
Date: Tue, 26 Jul 2005 11:04:58 -0700
In-Reply-To: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com> (Badari
 Pulavarty's message of "Tue, 26 Jul 2005 10:35:30 -0700")
Message-ID: <52wtndfnp1.fsf@topspin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Thanks, this is a good test.  It would be interesting to know if the
system does eventually deadlock with less system memory or with even
more filesystems.

 - R.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
