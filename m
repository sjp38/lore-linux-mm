Received: by nz-out-0506.google.com with SMTP id s1so362337nze
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 20:16:30 -0700 (PDT)
Message-ID: <b21f8390707252016o7f24ca8eg99e6895c7ab5cc53@mail.gmail.com>
Date: Thu, 26 Jul 2007 13:16:29 +1000
From: "Matthew Hawkins" <darthmdh@gmail.com>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <2c0942db0707251832i542249d5ve0006b3db0374678@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
	 <2c0942db0707250902v58e23d52v434bde82ba28f119@mail.gmail.com>
	 <b21f8390707251815o767590acrf6a6c4d7290a26a8@mail.gmail.com>
	 <2c0942db0707251832i542249d5ve0006b3db0374678@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/26/07, Ray Lee <ray-lk@madrabbit.org> wrote:
> Yeah, I know about inotify, but it doesn't scale.

Yeah, the nonrecursive behaviour is a bugger.  Also I found it helped
to queue operations in userspace and execute periodically rather than
trying to execute on every single notification.  Worked well for
indexing, for virus scanning though you'd want to do some risk
analysis.

It'd be nice to have a filesystem that handled that sort of thing
internally *cough*winfs*cough*.  That was my hope for reiserfs a very
long time ago with its pluggable fs modules feature.

-- 
Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
