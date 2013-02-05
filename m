Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 04DBE6B00F5
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 02:14:57 -0500 (EST)
Date: Tue, 5 Feb 2013 08:14:51 +0100 (CET)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH 10/18] mm: teach truncate_inode_pages_range() to handle
 non page aligned ranges
In-Reply-To: <20130204125136.b0926f20.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1302050814250.3225@localhost>
References: <1359715424-32318-1-git-send-email-lczerner@redhat.com> <1359715424-32318-11-git-send-email-lczerner@redhat.com> <20130201151502.59398b29.akpm@linux-foundation.org> <alpine.LFD.2.00.1302041510090.3225@localhost>
 <20130204125136.b0926f20.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="571107329-1464879651-1360048494=:3225"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, xfs@oss.sgi.com, Hugh Dickins <hughd@google.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--571107329-1464879651-1360048494=:3225
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Mon, 4 Feb 2013, Andrew Morton wrote:

> Date: Mon, 4 Feb 2013 12:51:36 -0800
> From: Andrew Morton <akpm@linux-foundation.org>
> To: Luka? Czerner <lczerner@redhat.com>
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
>     linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
>     xfs@oss.sgi.com, Hugh Dickins <hughd@google.com>
> Subject: Re: [PATCH 10/18] mm: teach truncate_inode_pages_range() to handle
>     non page aligned ranges
> 
> On Mon, 4 Feb 2013 15:51:19 +0100 (CET)
> Luk____ Czerner <lczerner@redhat.com> wrote:
> 
> > I hope I explained myself well enough :). Are you ok with this king
> > of approach ? If so, I'll resend the patch set without the
> > initialisation-at-declaration.
> 
> uh, maybe.  Next time I'll apply the patch and look at the end result! 
> Try to make it as understandable and (hence) maintainable as possible,
> OK?

Agreed.

Thanks!
-Lukas
--571107329-1464879651-1360048494=:3225--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
