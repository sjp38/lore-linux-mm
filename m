From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Date: Sun, 22 Apr 2001 11:21:56 +0100
Message-ID: <p1c5et4i6p6kc2loen28au8e7e3b4v4cqh@4ax.com>
References: <Pine.LNX.4.33.0104191609500.17635-100000@duckman.distro.conectiva> <Pine.LNX.4.30.0104201414400.20939-100000@fs131-224.f-secure.com>
In-Reply-To: <Pine.LNX.4.30.0104201414400.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmc@austin.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2001 14:29:57 +0200 (MET DST), you wrote:

>
>On Thu, 19 Apr 2001, Rik van Riel wrote:
>> Actually, this idea must have been in Unix since about
>> Bell Labs v5 Unix, possibly before.
>
>When people were happy they could sit down in front of a computer. But
>world changed since then. Users expectations are much higher, 

Hrm. How do you reconcile that with increasing use of Windows? :-)

>they want
>[among others] latency 

They want latency?! Just put them on a BT Internet connection then...

>and high availability.

Yes - which requires strangling rogue processes before they can take
the box out...

>> This is not a new idea, it's an old solution to an old
>> problem; it even seems to work quite well.
>
>Seems for who? AIX? "DON'T TOUCH IT!" I think HP-UX also has and it's
>not famous because of its stability. Sure, not because of this but maybe
>sometimes it contributes, maybe its design contributes, maybe its
>designers contribute.

Compared to other "desktop" OSs, Linux is excellent - compared to many
"commercial" Unixes, it still has weak points. It's rapidly improving,
but don't go thinking there is nothing to be learned from other, far
more mature, platforms...


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
