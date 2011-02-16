Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D66A08D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 19:01:02 -0500 (EST)
Received: by iwc10 with SMTP id 10so737774iwc.14
        for <linux-mm@kvack.org>; Tue, 15 Feb 2011 16:01:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110215223840.GA27420@sgi.com>
References: <20110215223840.GA27420@sgi.com>
Date: Wed, 16 Feb 2011 09:00:59 +0900
Message-ID: <AANLkTim+rjN8GMwOV5MLeVjXaevHmCciAc5DwQXgiO62@mail.gmail.com>
Subject: Re: [PATCH] - Improve drain pages performance on large systems
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>

On Wed, Feb 16, 2011 at 7:38 AM, Jack Steiner <steiner@sgi.com> wrote:
>
> Heavy swapping within a cpuset causes frequent calls to drain_all_pages()=
