Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
References: <1544824384-17668-1-git-send-email-longman@redhat.com>
In-Reply-To: <1544824384-17668-1-git-send-email-longman@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 16 Dec 2018 11:37:15 -0800
Message-ID: <CAHk-=wi-V7LjAAzFuxg+eLQAdp+Ay4WmVJdTNxgPjqKXaj-3Xw@mail.gmail.com>
Subject: Re: [RESEND PATCH v4 0/3] fs/dcache: Track # of negative dentries
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
To: Waiman Long <longman@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org, mcgrof@kernel.org, Kees Cook <keescook@chromium.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, mszeredi@redhat.com, Matthew Wilcox <willy@infradead.org>, lwoodman@redhat.com, James Bottomley <James.Bottomley@hansenpartnership.com>, wangkai86@huawei.com, Michal Hocko <mhocko@kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 14, 2018 at 1:53 PM Waiman Long <longman@redhat.com> wrote:
>
> This patchset addresses 2 issues found in the dentry code and adds a
> new nr_dentry_negative per-cpu counter to track the total number of
> negative dentries in all the LRU lists.

The series looks sane to me. I'm assuming I'll get it either though
-mm or from Al..

            Linus
