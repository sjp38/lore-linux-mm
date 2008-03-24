Received: by wx-out-0506.google.com with SMTP id h31so2921918wxd.11
        for <linux-mm@kvack.org>; Sun, 23 Mar 2008 21:20:02 -0700 (PDT)
Message-ID: <a36005b50803232120j63fb08d8p4a6cfdc8df2a3f21@mail.gmail.com>
Date: Sun, 23 Mar 2008 21:20:02 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
In-Reply-To: <20080322091001.GA7264@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080318104437.966c10ec.akpm@linux-foundation.org>
	 <20080319020440.80379d50.akpm@linux-foundation.org>
	 <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
	 <20080320090005.GA25734@one.firstfloor.org>
	 <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com>
	 <20080321172644.GG2346@one.firstfloor.org>
	 <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com>
	 <20080322071755.GP2346@one.firstfloor.org>
	 <1206170695.2438.39.camel@entropy>
	 <20080322091001.GA7264@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nicholas Miell <nmiell@comcast.net>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 22, 2008 at 2:10 AM, Andi Kleen <andi@firstfloor.org> wrote:
> > Why not stick the bitmap in an xattr?
>
>  xattrs are too small for potentially large binaries and a mess to manage
>  (a lot of tools don't know about them)

It does not matter a bit whether any other tool know about the xattrs.
 Binaries will not change after they are created to require changing
the attributes.  And it is no problem to not back the data up etc.
One really doesn't want to waste these resources.

And as far as the size limitation is concerned.  It depends on the
limit, which I don't know off hand.  But really, really big binaries
don't have to be treated like this anyway.  They are not started
frequently enough to justify this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
