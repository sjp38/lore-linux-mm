Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 7CE716B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 03:06:06 -0500 (EST)
Date: Fri, 22 Feb 2013 09:06:00 +0100 (CET)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH v2 10/18] mm: teach truncate_inode_pages_range() to handle
 non page aligned ranges
In-Reply-To: <20130221134905.9a1e2c9e.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1302220905200.14141@localhost>
References: <1360055531-26309-1-git-send-email-lczerner@redhat.com> <1360055531-26309-11-git-send-email-lczerner@redhat.com> <20130207154042.92430aed.akpm@linux-foundation.org> <alpine.LFD.2.00.1302080948110.3225@localhost> <alpine.LFD.2.00.1302210929590.19354@localhost>
 <20130221134905.9a1e2c9e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1987193048-1361520364=:14141"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1987193048-1361520364=:14141
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Thu, 21 Feb 2013, Andrew Morton wrote:

> Date: Thu, 21 Feb 2013 13:49:04 -0800
> From: Andrew Morton <akpm@linux-foundation.org>
> To: Luka? Czerner <lczerner@redhat.com>
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
>     linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
>     Hugh Dickins <hughd@google.com>
> Subject: Re: [PATCH v2 10/18] mm: teach truncate_inode_pages_range() to handle
>      non page aligned ranges
> 
> On Thu, 21 Feb 2013 09:33:56 +0100 (CET)
> Luk____ Czerner <lczerner@redhat.com> wrote:
> 
> > what's the status of the patch set ?
> 
> Forgotten about :(
> 
> > Can we get this in in this merge window ?
> 
> Please do a full resend after 3.9-rc1 and let's take it up again.
> 

I'll do that. Thanks.

-Lukas
--8323328-1987193048-1361520364=:14141--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
