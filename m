Received: by nz-out-0506.google.com with SMTP id s1so481261nze
        for <linux-mm@kvack.org>; Thu, 23 Aug 2007 17:07:58 -0700 (PDT)
Message-ID: <bd9320b30708231707l67d2d9d0l436a229bd77a86f@mail.gmail.com>
Date: Thu, 23 Aug 2007 17:07:58 -0700
From: mike <mike503@gmail.com>
Subject: Drop caches - is this safe behavior?
In-Reply-To: <bd9320b30708231645x3c6524efi55dd2cf7b1a9ba51@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <bd9320b30708231645x3c6524efi55dd2cf7b1a9ba51@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have a crontab running every 5 minutes on my servers now:

    echo 2 > /proc/sys/vm/drop_caches

Is this a safe thing to do? Am I risking any loss of data? It looks
like "3" might allow for that but from what I can understand 0-2 won't
lose data.

I was seeing some issues with my memory being taken up and thrown all
into "cached" and eventually starts swapping (not a lot, but a little)
- supposedly memory in "cached" is supposed to be available for new
stuff, but I swear it is not. I've tried a variety of things, and this
drop caches trick seems to make me feel quite comfortable seeing it be
free as in free physical RAM, not stuck in the cache.

So far it appears to be keeping my webservers' memory usage tolerable
and expected, as opposed to rampant and greedy. I haven't seen any
loss in functionality either. These servers get all their files (sans
local /var /etc stuff) from NFS, so I don't think a local memory-based
cache needs to be that important.

I've been trying to find more information on the drop_caches parameter
and its effects but it appears to be too new and not very widespread.
Any help is appreciated. Perhaps this is a safe behavior on a
non-primary file storage system like a webserver mounting NFS, but the
NFS server itself should not?

Thanks,
mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
