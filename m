Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C0B9E6B0036
	for <linux-mm@kvack.org>; Tue, 28 May 2013 07:21:49 -0400 (EDT)
Date: Tue, 28 May 2013 07:21:44 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v4 00/20] change invalidatepage prototype to accept length
Message-ID: <20130528112144.GA11839@thunk.org>
References: <1368549454-8930-1-git-send-email-lczerner@redhat.com>
 <alpine.LFD.2.00.1305211622330.2469@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LFD.2.00.1305211622330.2469@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?THVrw6HFoQ==?= Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, hughd@google.com

On Tue, May 21, 2013 at 04:34:25PM +0200, LukA!A! Czerner wrote:
> On Tue, 14 May 2013, Lukas Czerner wrote:
> 
> > Date: Tue, 14 May 2013 18:37:14 +0200
> > From: Lukas Czerner <lczerner@redhat.com>
> > To: linux-mm@kvack.org
> > Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
> >     linux-ext4@vger.kernel.org, akpm@linux-foundation.org, hughd@google.com,
> >     lczerner@redhat.com
> > Subject: [PATCH v4 00/20] change invalidatepage prototype to accept length
> 
> Hi Ted,
> 
> you've mentioned that you'll carry the changed in the ext4 tree. Are
> you going to take it for the next merge window ?
> 
> However I still need some review on the mm part of the series,
> Andrew, Hugh, anyone ?

The ext4 tree now has the the v4 version of hte invalidatepage range
patches in it.  So it will be showing up in the next linux-next tree,
for the convenience of the mm folks.  :-)

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
