Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 44AB16B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 11:11:45 -0400 (EDT)
Date: Fri, 2 Aug 2013 08:11:41 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: named anonymous vmas
Message-ID: <20130802151141.GA4439@infradead.org>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
 <20130622103158.GA16304@infradead.org>
 <CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com>
 <20130801082951.GA23563@infradead.org>
 <20130801083608.GJ221@brightrain.aerifal.cx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130801083608.GJ221@brightrain.aerifal.cx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rich Felker <dalias@aerifal.cx>
Cc: Christoph Hellwig <hch@infradead.org>, Colin Cross <ccross@google.com>, lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, John Stultz <john.stultz@linaro.org>, libc-alpha@sourceware.org

On Thu, Aug 01, 2013 at 04:36:08AM -0400, Rich Felker wrote:
> I'm not sure what the purpose is. shm_open with a long random filename
> and O_EXCL|O_CREAT, followed immediately by shm_unlink, is just as
> good except in the case where you have a malicious user killing the
> process in between these two operations.

The Android people already have an shm API doesn't leave traces in the
filesystem, and I at least conceptually agree that having an API that
doesn't introduce posisble other access is a good idea.  This is the
same reason why the O_TMPFILE API was added in this releases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
