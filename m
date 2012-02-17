Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 87F9E6B00F1
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 09:51:12 -0500 (EST)
Subject: Re: [WIP 11/18] Basic support (faulting) for huge pages for shmfs
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Fri, 17 Feb 2012 15:51:11 +0100
From: =?UTF-8?Q?Rados=C5=82aw_Smogura?= <mail@smogura.eu>
In-Reply-To: <20120217144118.GB19606@thunk.org>
References: <1329403677-25629-1-git-send-email-mail@smogura.eu>
 <20120216234233.GE26473@thunk.org>
 <bdec95398caa767d4ee9c998e49dddda@rsmogura.net>
 <20120217144118.GB19606@thunk.org>
Message-ID: <f78370f3c3fefc9b89c44522f874730d@rsmogura.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ted Ts'o <tytso@mit.edu>
Cc: linux-mm@kvack.org, Yongqiang Yang <xiaoqiangnk@gmail.com>, linux-ext4@vger.kernel.org

On Fri, 17 Feb 2012 09:41:18 -0500, Ted Ts'o wrote:
> On Fri, Feb 17, 2012 at 03:12:44PM +0100, RadosA?aw Smogura wrote:
>> On Thu, 16 Feb 2012 18:42:33 -0500, Ted Ts'o wrote:
>> >OK, stupid question... where are patches 1 through 10?  I'm 
>> guessing
>> >linux-ext4 wasn't cc'ed on them?
>> >
>> >					- Ted
>> Actually, I added those for --cc (checked in command history). I
>> think problems went from mail server, it first sent 10 first
>> patches, then no more, after 20 min I resented patches from 11, but
>> after few hours some "not sent" patches were sent (I putted self to
>> cc, so I know). Now, I see those at
>> http://www.spinics.net/lists/linux-ext4/.
>
> Ok, so there's no difference between the patches sent yesterday with
> "WIP" in the subject line, and the ones which didn't?  It was just a
> resend, then, correct?
>
>       	     	     	       	   	- Ted
Yes, indeed.
Regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
