Received: by wr-out-0506.google.com with SMTP id 57so1472325wri
        for <linux-mm@kvack.org>; Tue, 22 May 2007 01:45:07 -0700 (PDT)
Message-ID: <84144f020705220145vb96b91eqa0ef6f1c25d1e5ff@mail.gmail.com>
Date: Tue, 22 May 2007 11:45:06 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
In-Reply-To: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/21/07, Christoph Lameter <clameter@sgi.com> wrote:
> I finally found a way to get rid of the nasty list of comparisions in
> slub_def.h. ilog2 seems to work right for constants.

Nice cleanup Christoph! Looks good to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
