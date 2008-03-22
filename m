Received: by hs-out-0708.google.com with SMTP id j58so1283818hsj.6
        for <linux-mm@kvack.org>; Fri, 21 Mar 2008 21:36:51 -0700 (PDT)
Message-ID: <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com>
Date: Fri, 21 Mar 2008 21:36:51 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
In-Reply-To: <20080321172644.GG2346@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080318003620.d84efb95.akpm@linux-foundation.org>
	 <20080318095715.27120788.akpm@linux-foundation.org>
	 <20080318172045.GI11966@one.firstfloor.org>
	 <20080318104437.966c10ec.akpm@linux-foundation.org>
	 <20080319083228.GM11966@one.firstfloor.org>
	 <20080319020440.80379d50.akpm@linux-foundation.org>
	 <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
	 <20080320090005.GA25734@one.firstfloor.org>
	 <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com>
	 <20080321172644.GG2346@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 21, 2008 at 10:26 AM, Andi Kleen <andi@firstfloor.org> wrote:
>  Concrete suggestions please.

I already spelled it out.  Add a new program header entry, point it to
a bit array large enough to cover all loadable segments.

It is not worth creating problems with this invalid extension just for
old binaries.  Just let those go.  New binaries can automatically get
the array and then there are no extra seeks, the format is well
defined, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
