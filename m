Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3523D6B003B
	for <linux-mm@kvack.org>; Tue, 21 May 2013 03:27:47 -0400 (EDT)
Message-ID: <519B2224.50105@parallels.com>
Date: Tue, 21 May 2013 11:28:36 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: vmscan: add VM_BUG_ON on illegal return values
 from scan_objects
References: <1369120410-18180-1-git-send-email-oskar.andero@sonymobile.com> <CAOJsxLGivq0p1j4Axykdz-O8FtYfn=M1BfLEnc=q-fjxA2Yonw@mail.gmail.com>
In-Reply-To: <CAOJsxLGivq0p1j4Axykdz-O8FtYfn=M1BfLEnc=q-fjxA2Yonw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Oskar Andero <oskar.andero@sonymobile.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Radovan Lekanovic <radovan.lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh
 Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 05/21/2013 11:17 AM, Pekka Enberg wrote:
> It seems to me relaxing the shrinker API restrictions and changing the
> "ret == -1" to "ret < 0" would be a much more robust approach...

Dave had already spoken against it, and I agree with him
Anybody returning any negative value different than -1 is definitely
doing something strange


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
