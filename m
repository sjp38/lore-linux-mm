Date: Wed, 7 Jun 2000 18:11:44 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM
Message-ID: <20000607181144.U30951@redhat.com>
References: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva> <393DA31A.358AE46D@reiser.to> <20000607121243.F29432@redhat.com> <m2r9a9a1q6.fsf_-_@boreas.southchinaseas>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2r9a9a1q6.fsf_-_@boreas.southchinaseas>; from vii@penguinpowered.com on Wed, Jun 07, 2000 at 05:35:13PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 05:35:13PM +0100, John Fremlin wrote:
> 
> You are saying, that the MM system maintains a list of pages, then
> when it wants to free some memory it goes down the list seeing which
> subsystem owns each page, and asks it to free some memory. (Correct me
> if I am wrong).
> That is, each filesystem or whatever can basically implement its own
> MM. If so, why not simply have a list of subsystems that own memory
> with some sort of measure of how much space they're wasting, and ask
> the ones with a lot to free some?

Because you want to have some idea of the usage patterns of the 
pages, too, so that you can free pages which haven't been accessed 
recently regardless of who owns them.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
