Received: by wa-out-1112.google.com with SMTP id j37so204180waf.22
        for <linux-mm@kvack.org>; Thu, 23 Oct 2008 07:14:41 -0700 (PDT)
Message-ID: <84144f020810230714g7f5d36bas812ad691140ee453@mail.gmail.com>
Date: Thu, 23 Oct 2008 17:14:41 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <Pine.LNX.4.64.0810230705210.12497@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1223883004.31587.15.camel@penberg-laptop>
	 <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
	 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221416130.26639@quilx.com>
	 <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>
	 <1224745831.25814.21.camel@penberg-laptop>
	 <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810230638450.11924@quilx.com>
	 <84144f020810230658o7c6b3651k2d671aab09aa71fb@mail.gmail.com>
	 <Pine.LNX.4.64.0810230705210.12497@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 23, 2008 at 5:09 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> Got a draft of a patch here that does freelist handling differently. Instead
> of building linked lists it uses free objects to build arrays of pointers to
> free objects. That improves cache cold free behavior since the object
> contents itself does not have to be touched on free.
>
> The problem looks like its freeing objects on a different processor that
> where it was used last. With the pointer array it is only necessary to touch
> the objects that contain the arrays.

Interesting. SLAB gets away with this because of per-cpu caches or
because it uses the bufctls instead of a freelist?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
