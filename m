Date: Thu, 1 Feb 2001 14:36:06 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] vma limited swapin readahead
Message-ID: <20010201143606.P11607@redhat.com>
References: <20010201112601.K11607@redhat.com> <Pine.LNX.4.21.0102010824000.17822-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0102010824000.17822-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Thu, Feb 01, 2001 at 08:53:33AM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, David Gould <dg@suse.com>, "Eric W. Biederman" <ebiederm@xmission.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Feb 01, 2001 at 08:53:33AM -0200, Marcelo Tosatti wrote:
> 
> On Thu, 1 Feb 2001, Stephen C. Tweedie wrote:
> 
> If we're under free memory shortage, "unlucky" readaheads will be harmful.

I know, it's a balancing act.  But given that even one successful
readahead per read will halve the number of swapin seeks, the
performance loss due to the extra scavenging has got to be bad to
outweigh the benefit.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
