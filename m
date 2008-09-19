Received: by wa-out-1112.google.com with SMTP id m28so455403wag.8
        for <linux-mm@kvack.org>; Fri, 19 Sep 2008 15:02:09 -0700 (PDT)
Message-ID: <84144f020809191502i35805980n97dc3073ab8a52bc@mail.gmail.com>
Date: Sat, 20 Sep 2008 01:02:09 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 3/3] Increase default reserve percpu area
In-Reply-To: <20080919203724.474751340@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080919203703.312007962@quilx.com>
	 <20080919203724.474751340@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 19, 2008 at 11:37 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> SLUB now requires a portion of the per cpu reserve. There are on average
> about 70 real slabs on a system (aliases do not count) and each needs 12 bytes
> of per cpu space. Thats 840 bytes. In debug mode all slabs will be real slabs
> which will make us end up with 150 -> 1800. Give it some slack and add 2000
> bytes to the default size.
>
> Things work fine without this patch but then slub will reduce the percpu reserve
> for modules.

Hmm, shouldn't this be dynamically configured at runtime by
multiplying the number of possible CPUs with some constant?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
