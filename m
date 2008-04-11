Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m3BDn4Gj024302
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 14:49:04 +0100
Received: from fg-out-1718.google.com (fge13.prod.google.com [10.86.5.13])
	by zps36.corp.google.com with ESMTP id m3BDn0Ai028543
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 06:49:01 -0700
Received: by fg-out-1718.google.com with SMTP id 13so374747fge.20
        for <linux-mm@kvack.org>; Fri, 11 Apr 2008 06:49:00 -0700 (PDT)
Message-ID: <d43160c70804110649q1b099b02n835f90c5651f3073@mail.gmail.com>
Date: Fri, 11 Apr 2008 09:49:00 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: [PATCH 1/2] MM: Make Page Tables Relocatable -- conditional flush
In-Reply-To: <20080410172603.98224DCA40@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080410172603.98224DCA40@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rossb@google.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 10, 2008 at 1:26 PM, Ross Biro <rossb@google.com> wrote:
>  rcu cleanup.  There still appears to be a race, but it looks like it's
>  in the rcu code.  If I reduce the migration code to
>
>  down_interruptible()
>  synchronize_rcu()
>  up()
>
>  I still get a crash about once every 1-2 million times through the
>  loop.  If the race is in my code, it's something stupid.  Otherwise
>  it's elsewhere and my code won't make things anyworse.

This race appears to have been fixed between 2.6.25rc5-mm1 and
2.6.25rc8-mm1.  I've been running the later over night and have over 7
million iterations with out a crash.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
