Received: by nz-out-0506.google.com with SMTP id i11so335769nzh.26
        for <linux-mm@kvack.org>; Wed, 09 Jan 2008 20:39:02 -0800 (PST)
Message-ID: <170fa0d20801092039w22584e2fw6821e70157f55cae@mail.gmail.com>
Date: Wed, 9 Jan 2008 23:39:02 -0500
From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [patch 00/19] VM pageout scalability improvements
In-Reply-To: <20080108205939.323955454@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080108205939.323955454@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Jan 8, 2008 3:59 PM, Rik van Riel <riel@redhat.com> wrote:
> On large memory systems, the VM can spend way too much time scanning
> through pages that it cannot (or should not) evict from memory. Not
> only does it use up CPU time, but it also provokes lock contention
> and can leave large systems under memory presure in a catatonic state.
>
> Against 2.6.24-rc6-mm1

Hi Rik,

How much trouble am I asking for if I were to try to get your patchset
to fly on a fairly recent "stable" kernel (e.g. 2.6.22.15)?  If
workable, is such an effort before it's time relative to your TODO?

I see that you have an old port to a FC7-based 2.6.21 here:
http://people.redhat.com/riel/vmsplit/

Also, do you have a public git repo that you regularly publish to for
this patchset?  If not a git repo do you put the raw patchset on some
http/ftp server?

thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
