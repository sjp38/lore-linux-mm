Received: by yw-out-1718.google.com with SMTP id 5so1392112ywm.26
        for <linux-mm@kvack.org>; Tue, 27 May 2008 09:06:56 -0700 (PDT)
Message-ID: <2f11576a0805270906x35a1f15eu7fe7414bbfe5c4b4@mail.gmail.com>
Date: Wed, 28 May 2008 01:06:55 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] slub: record page flag overlays explicitly
In-Reply-To: <20080527145250.GA3407@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <exportbomb.1211560342@pinky> <1211560402.0@pinky>
	 <20080526133755.4664.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080527145250.GA3407@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> > -           if (SlabDebug(page))
>> > -                   printk(KERN_ERR "SLUB %s: SlabDebug set on "
>> > +           if (PageSlubDebug(page))
>> > +                   printk(KERN_ERR "SLUB %s: SlubDebug set on "
>> >                             "slab 0x%p\n", s->name, page);
>> >     }
>> >  }
>>
>> Why if(SLABDEBUG) check is unnecessary?
>
> They were unconditional before as well.  SlabDebug would always return
> 0 before the patch.  The point being, to my reading, that if you asked
> for debug on the slab and debug was not compiled in you would still get
> told that it was not set; which it cannot without the support.

Thank you explain!

  Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
